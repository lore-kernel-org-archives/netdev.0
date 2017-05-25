From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Thu, 25 May 2017 15:49:14 -0400 (EDT)
Message-ID: <20170525.154914.1347048861561693629.davem@davemloft.net>
References: <20170523143616.38116e8f@gmail.com>
        <20170525.121117.810915705354733044.davem@davemloft.net>
        <20170526054627.00dcdeeb@udesktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: petedaws@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526054627.00dcdeeb@udesktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Dawson <petedaws@gmail.com>
Date: Fri, 26 May 2017 05:46:27 +1000

> On Thu, 25 May 2017 12:11:17 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> > Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=195661  
>> 
>> This is not the correct way to use the Fixes: tag.
>> 
>> You should specify the commit that introduced the regression
>> between 4.9.x and 4.10.x, and that you are fixing here.
> 
> Thanks for your review Dave. I'll resubmit the patch with the following detail and just reference the bugzilla in the main body of the commit comment.
> 
> Commit 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0") caused the regression by masking out the flowlabel which exposed the incorrect the handling of the DSCP portion of the flowlabel in ip6_tunnel and ip6_gre.

Still not correct, you need to use a "Fixes: " tag of the form:

Fixes: 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0")

And it must appear of the first line of tags, before signoffs and acks,
with no empty lines in between.

Thank you.
