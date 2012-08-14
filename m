From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net PATCH v1 1/2] net: netprio: fix files lock and remove useless
 d_path bits
Date: Mon, 13 Aug 2012 19:59:52 -0700
Message-ID: <5029BF28.5030101@intel.com>
References: <20120814013939.3144.13167.stgit@jf-dev1-dcblab> <20120814022951.GF23464@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814022951.GF23464@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/13/2012 7:29 PM, Al Viro wrote:
> On Mon, Aug 13, 2012 at 06:39:39PM -0700, John Fastabend wrote:
>> -			path = d_path(&file->f_path, tmp, PAGE_SIZE);
>
> What's using tmp after that patch and do you still need to bother
> allocating it?
>

nothing removed it in v2.
