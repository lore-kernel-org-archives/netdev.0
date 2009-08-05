From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 06 Aug 2009 07:50:38 +0900
Message-ID: <4A7A0CBE.4020304@ring3k.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at> <392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com> <4A78BC48.4060200@gibraltar.at> <4A78BD5F.2030901@mayrhofer.eu.org> <4A78CA13.6040409@ring3k.org> <4A7977A0.7070807@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Rene Mayrhofer <rene@mayrhofer.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:62813 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbZHEWxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 18:53:36 -0400
Received: by rv-out-0506.google.com with SMTP id f6so132394rvb.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 15:53:37 -0700 (PDT)
In-Reply-To: <4A7977A0.7070807@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rene Mayrhofer wrote:

> What would be the simplest change to stop disabling phy when the last
> device goes down?

Commenting out the following line should stop all the phys from powering off:

sky2_phy_power_down(hw, port);

If you have a chance, please test "sky2: Add a mutex around ethtools operations" also.
it probably won't fix the problem you're seeing, but you never know...

thanks,

Mike

