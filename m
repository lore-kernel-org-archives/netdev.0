From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Grant copy the header instead of
 map and memcpy
Date: Thu, 27 Mar 2014 15:16:58 +0000
Message-ID: <533440EA.20608@citrix.com>
References: <1395868707-22683-1-git-send-email-zoltan.kiss@citrix.com> <1395920136.22909.76.camel@kazak.uk.xensource.com> <53341DA8.9010102@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53341DA8.9010102@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/03/14 12:46, Zoltan Kiss wrote:
> On 27/03/14 11:35, Ian Campbell wrote:
>> On Wed, 2014-03-26 at 21:18 +0000, Zoltan Kiss wrote:
>> You've added a second hypercall to tx_action, probably those can be
>> combined into one vm exit by using a multicall.
> Yes, good idea!

Thinking a bit further, it would need some grant-table.c changes first. 
I've put it onto my todo list.

Zoli
