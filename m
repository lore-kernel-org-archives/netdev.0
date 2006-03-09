From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add
 percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 18:32:06 -0800
Message-ID: <20060308183206.76215706.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308015934.GB9062@localhost.localdomain>
	<20060307181301.4dd6aa96.akpm@osdl.org>
	<20060308202656.GA4493@localhost.localdomain>
	<20060308203642.GZ5410@kvack.org>
	<20060308210726.GD4493@localhost.localdomain>
	<20060308211733.GA5410@kvack.org>
	<20060308222528.GE4493@localhost.localdomain>
	<20060308150609.344c62fa.akpm@osdl.org>
	<p733bhswe6j.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161004AbWCICeN@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <p733bhswe6j.fsf@verdi.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote:
>
> Andrew Morton <akpm@osdl.org> writes:
> > 
> > x86_64 is signed 32-bit!
> 
> I'll change it. You want signed 64bit?
> 

Well it's all random at present.  Since the API is defined as unsigned I
guess it's be best to make it unsigned for now.  Later, when someone gets
down to making it signed and reviewing all the users they can flip x86_64
to signed along with the rest of the architectures.
