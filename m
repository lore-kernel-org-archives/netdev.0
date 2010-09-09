From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Problems obtaining software TX timestamps
Date: Thu, 9 Sep 2010 15:57:16 +0200
Message-ID: <20100909135716.GA8706@riccoc20.at.omicron.at>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
 <1283958771.2748.85.camel@edumazet-laptop>
 <4C87FE60.7090209@edu.uni-klu.ac.at>
 <20100909063541.GA3305@riccoc20.at.omicron.at>
 <4C889A1E.6050405@edu.uni-klu.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35954 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276Ab0IIN52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:57:28 -0400
Received: by bwz11 with SMTP id 11so1125641bwz.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 06:57:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C889A1E.6050405@edu.uni-klu.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 10:26:06AM +0200, Ingo Kofler wrote:
> Thank you very much for this clarification. Are there any drawbacks
> with this approach, e.g. performance issues? Honestly, I am just
> wondering why driver developers do not add this single line if it's
> that easy....

Adding the line only tests one flag, so it is not a huge performance
hit. This fix is very recent, that is why it has not been used in MAC
drivers yet.

Richard

