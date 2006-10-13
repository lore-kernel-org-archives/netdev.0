From: David Johnson <dj@david-web.co.uk>
Subject: Re: Hardware bug or kernel bug?
Date: Fri, 13 Oct 2006 17:24:39 +0100
Message-ID: <200610131724.40631.dj@david-web.co.uk>
References: <20061013085605.GA1690@ff.dom.local> <200610131256.54546.dj@david-web.co.uk> <20061013130648.GC1690@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751731AbWJMQYq@vger.kernel.org>
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061013130648.GC1690@ff.dom.local>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 October 2006 14:06, Jarek Poplawski wrote:
>
> Probably - but only with networking. So I'd try with this debugging
> like in my first reply plus maybe 2.6.19-rc1 (e1000 - btw. I hope
> this other tested card was different model - and locking improved)
> and resend conclusions to netdev@vger.kernel.org.
>

OK I built a 2.6.19-rc1 kernel with a minimal config as you describe and I 
cannot reproduce the reboots with this kernel. My .config:
http://www.david-web.co.uk/download/config

The other NIC I tried was a D-Link DL10050-based card which I think uses the 
dl2k module.

I tried to reproduce the problem under Windows (2k), which didn't reboot but 
did still suffer from it I believe. Randomly during an scp transfer (using 
the PuTTY scp client) Windows will lock-up for about 30 seconds, making an 
entry in the event log indicating that there was a time-out talking to the 
IDE controller, then continuing. Could the same thing be happening in Linux? 
If Linux can't talk to the IDE controller when trying to write to disk, how 
does it handle that?

Regards,
David.
