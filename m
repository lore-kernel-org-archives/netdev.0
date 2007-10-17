From: Patrick McHardy <kaber@trash.net>
Subject: Re: Difference between device statistics from ifconfig and ip -s
 l	l
Date: Wed, 17 Oct 2007 12:35:43 +0200
Message-ID: <4715E57F.6080905@trash.net>
References: <20071017092659.GA16356@wq.cz> <4715D79E.7020201@trash.net> <20071017101303.GB16356@wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36637 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbXJQKfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 06:35:45 -0400
In-Reply-To: <20071017101303.GB16356@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milan Kocian wrote:
> On Wed, Oct 17, 2007 at 11:36:30AM +0200, Patrick McHardy wrote:
>
>> ifconfig gets its data from /proc/net/dev, which adds up rx_errors
>> and rx_missed.
>>
> 
> Adds up rx_errors and rx_missed and prints it as dropped ? Ok, ifconfig is
> a little old. But why I don't see missed packets from RX errors detailed stats 
> (ip -s -s l l) in non-detailed stats as errors and see zero ?


I meant to write "adds up rx_dropped and rx_missed".
