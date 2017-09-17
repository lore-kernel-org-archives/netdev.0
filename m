From: Cole Robinson <crobinso@redhat.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Sun, 17 Sep 2017 09:17:13 -0400
Message-ID: <10124256-647f-99a5-aa29-8073438a21df@redhat.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
 <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
 <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
 <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
 <813386f2-81ba-db8c-e86d-f36cd1b89537@redhat.com>
 <BD049B00-DD0A-449F-A017-9E73178685DE@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>, Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BD049B00-DD0A-449F-A017-9E73178685DE@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/2017 01:51 PM, Josef Bacik wrote:
> Finally got access to a box to run this down myself.  This patch on top of the other patches fixes the problem for me, could you verify it works for you?  Thanks,
> 

Yup I can confirm that patch fixes things when applied on top of the
previous 3 patches. Thanks! Please tag those patches for stable releases
if appropriate, this is affecting a decent amount of libvirt users

Thanks,
Cole
