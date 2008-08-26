From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 11:07:46 +0000
Message-ID: <20080826110746.GC2609@ff.dom.local>
References: <20080826095126.GA2609@ff.dom.local> <200808261329.53741.denys@visp.net.lb> <20080826104717.GB2609@ff.dom.local> <200808261349.09820.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757696AbYHZLIM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200808261349.09820.denys@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2008 at 01:49:09PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 26 August 2008, Jarek Poplawski wrote:
> > The question is if you really need so exact shaping at a cost of
> > higher system load.
> Thats maybe another reason to have your patch in mainline :-)

We should be first sure when it's really needed.

> I will try it today with this case, if it will help.
> 
> Maybe it can be optional, and enabled via kernel parameter and /sys , so it 
> can be useful in case of crashes when TSC used and when timer is too slow.
> Because it is not so useful just to disable hrtimers completely, if you need 
> them for some other task...

Maybe it could be enough to use current parameters like: "highres=off"
according to Documentation/kernel-parameters.txt?

Jarek P.
