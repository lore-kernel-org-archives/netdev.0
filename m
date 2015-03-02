From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 4/4] switchdev: don't support custom ip rules,
 for now
Date: Mon, 02 Mar 2015 06:36:15 -0800
Message-ID: <54F4755F.6020205@cumulusnetworks.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com> <1425290777-22702-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39632 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529AbbCBOgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 09:36:18 -0500
Received: by pablf10 with SMTP id lf10so44053683pab.6
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 06:36:17 -0800 (PST)
In-Reply-To: <1425290777-22702-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Keep switchdev FIB offload model simple for now and don't allow custom ip
> rules.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

I don't see a need to do this. And seems very aggressive.
Also, note that the rules in a system can be on non-hw accelerated ports.

Until rules are hw accelerated, its ok to document this limitation for 
hw accelerated routes in my opinion.
