From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Patch: Fix fec_mpc52xx driver to use net_device_ops
Date: Tue, 31 Mar 2009 10:42:32 -0600
Message-ID: <fa686aa40903310942q7ae3c246g10a862b44cf29e15@mail.gmail.com>
References: <ae4f76fd0903310344s2d46edf2l505a1d21a4778d54@mail.gmail.com>
	 <20090331074806.432a882a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Henk Stegeman <henk.stegeman@gmail.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:35454 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093AbZCaQme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 12:42:34 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3114080rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 09:42:32 -0700 (PDT)
In-Reply-To: <20090331074806.432a882a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 8:48 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 31 Mar 2009 12:44:15 +0200
> Henk Stegeman <henk.stegeman@gmail.com> wrote:
>
>> Fix fec_mpc52xx driver to use net_device_ops and to be careful not to
>> dereference phy_device if a phy has not yet been connected.
>>
>> Signed-off-by: Henk Stegeman <henk.stegeman@gmail.com>

Hi Henk,

I hadn't heard from you for a while about the signed-off-by line, but
I really needed to get those changes queued because the 2.6.30 merge
window is open now, and some of my patches depend on it.  I ended up
rewriting your patch from scratch, testing it and posting it last
night.

I would really like to stick with the rewritten version since it is a
little tighter, and it is the one I've got tested.  However, now that
I've heard from you, I'm happy to change the patch author credit to
you.  You should look on the list for the patches I sent out last
night (labeled [PATCH 02/14] and [PATCH 03/14]) and reply to each of
them with an "Acked-by:" line if they look good to you.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
