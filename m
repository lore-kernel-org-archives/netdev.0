From: Milan Kocian <milon@wq.cz>
Subject: Re: Difference between device statistics from ifconfig and ip -s l
	l
Date: Wed, 17 Oct 2007 13:29:20 +0200
Message-ID: <20071017112919.GC16356@wq.cz>
References: <20071017092659.GA16356@wq.cz> <4715D79E.7020201@trash.net> <20071017101303.GB16356@wq.cz> <4715E57F.6080905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:52357 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758466AbXJQL3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 07:29:25 -0400
Content-Disposition: inline
In-Reply-To: <4715E57F.6080905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 12:35:43PM +0200, Patrick McHardy wrote:
> Milan Kocian wrote:
>> On Wed, Oct 17, 2007 at 11:36:30AM +0200, Patrick McHardy wrote:
>>
>>> ifconfig gets its data from /proc/net/dev, which adds up rx_errors
>>> and rx_missed.
>>>
>> Adds up rx_errors and rx_missed and prints it as dropped ? Ok, ifconfig is
>> a little old. But why I don't see missed packets from RX errors detailed 
>> stats (ip -s -s l l) in non-detailed stats as errors and see zero ?
>
>
> I meant to write "adds up rx_dropped and rx_missed".

ok.

One probably stupid question: Why is not done similar sum in output of 'ip -s l l' ?

Imagine me :), I do 'ifconfig' and see dropped packets and then I do 'ip -s l l'
and see zeros. I stare on it like an idiot. Where is bug ? ifconfig ? ip ?
(man page of ip and 'ip -s -s l l' with missed packets stats saved me :).

IMHO I think that comparable outputs of both programs should be still the same.

thanks for reply.

regards,

-- 
Milan Kocian
