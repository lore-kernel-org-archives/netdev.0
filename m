From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange TCP behavior over HSDPA
Date: Tue, 29 Dec 2009 10:57:48 +0000
Message-ID: <20091229105748.GB7209@ff.dom.local>
References: <20091229083050.GA7209@ff.dom.local> <4B39D30F.8090006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:45369 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbZL2K54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 05:57:56 -0500
Received: by fg-out-1718.google.com with SMTP id 19so4701681fgg.1
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 02:57:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B39D30F.8090006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 10:59:43AM +0100, Kristian Evensen wrote:
> Den 29.12.2009 09:30, skrev Jarek Poplawski:
>> The most obvious difference seems to be the SACK option used in [2],
>> so maybe something on the route breaks it (without tunnels).
>>
>> Jarek P.
>>    
> Thank you for your reply. I have tried disabling SACK and then the  
> performance when packet loss occured got even worse, and the rest of the  
> time it was pretty similar.

Did you try to turn off TCP window scaling btw? Anyway, under the
tunnel ([2]), when SACK worked, it saved you a lot of retransmits.

Jarek P.
