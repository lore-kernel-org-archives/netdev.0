From: Steve Modica <modica@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Fri, 10 Oct 2003 14:05:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8702FF.70500@sgi.com>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com> <20031008202248.GA15611@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, johnip@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008202248.GA15611@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Andi Kleen wrote:

> 
> For 2.6 short term probably some bandaid like the CONFIG_UNALIGNMENT_COSTLY 
> and doing driver copies is better.
> 

Question.

Is there a way for us to create a CONFIG entry like this, but also allow for a 
modules.conf argument?  (perhaps "options tg3 unalignment_costly")

Customers running Suse on Altix have to edit modules.conf anyhow so they use the 
tg3 module (instead of bcm).  So when they do this, we could easily have them 
add an argument to the modules.conf line and we avoid a kernel build. This let's 
us run with a standard ia64 kernel.

Steve

-- 
Steve Modica
work: 651-683-3224
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
