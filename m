From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [BUG] MODULE_PARM conversions introduces bug in Wavelan driver
Date: Wed, 19 Jan 2005 13:42:33 +1100
Message-ID: <1106102553.20879.4.camel@localhost.localdomain>
References: <20050119004722.GA26468@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261554AbVASD66@vger.kernel.org>
To: jt@hpl.hp.com
In-Reply-To: <20050119004722.GA26468@bougret.hpl.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-18 at 16:47 -0800, Jean Tourrilhes wrote:
> 	Hi Rusty,
> 
> 	(If you are not the culprit, please forward to the guilty party).

Almost certainly me.  We gave people warning, we even marked MODULE_PARM
deprecated, but eventually I had to roll through and try to autoconvert.

> 	I personally introduced the "double char array" module
> parameter, 'c', to fix that. I even sent you the patch to add 'c'
> support in your new module loader (see set_obsolete()). Would it be
> possible to carry this feature with the new module_param_array ?
> 	Thanks in advance...

Actually, it's designed so you can extend it yourself: at its base,
module_param_call() is just a callback mechanism.

Thanks!
Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman
