From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 13 Sep 2016 11:57:35 -0400 (EDT)
Message-ID: <20160913.115735.1397234520899437294.davem@davemloft.net>
References: <20160910220528.GB2001@uranus.lan>
        <c5889fbd-ad20-0626-be1f-9d09a1d35b1a@cumulusnetworks.com>
        <20160911191714.GC2001@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: gorcunov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160911191714.GC2001@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sun, 11 Sep 2016 22:17:15 +0300

> On Sat, Sep 10, 2016 at 04:28:40PM -0600, David Ahern wrote:
>> On 9/10/16 4:05 PM, Cyrill Gorcunov wrote:
>> > On Sat, Sep 10, 2016 at 10:31:35AM -0600, David Ahern wrote:
>> >>
>> >> Would you mind adding the destroy capability as well? The udp version
>> >> should be close to what is needed for raw sockets. See udp_diag_destroy
>> >> and udp_abort.
>> > 
>> > Should be something like below. Didn't tested it yet so for review only.
>> > Will do testing at Monday.
>> 
>> doesn't compile:
>> - raw_abort needs to be in a header for ipv6, and
>> - inet_sk_diag_fill args have changed due to a recent commit
> 
> Thanks for review, David. I updated against net-next.

Please do not post new versions of patches as replies to existing
discussions.

Instead, make fresh patch postings to the list.

Thanks.
