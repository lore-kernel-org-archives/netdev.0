From: Jean Tourrilhes <jt-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Thu, 15 Jul 2004 10:00:24 -0700
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <20040715170024.GH25405@bougret.hpl.hp.com>
References: <m34qo96x8m.fsf@averell.firstfloor.org>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	the_nihilant-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Andi Kleen <ak-h9bWGtP8wOw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m34qo96x8m.fsf-uMLt6ZyWIM1XD82W0jV7G5GkACoKc3Ta@public.gmane.org>
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5ji9XKYC2TYK4Io4DoRGLOrNAH6kLmebB@public.gmane.org>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5lLLH9aP38KF1pqr+6INuaA@public.gmane.org>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5R9m/fhtKvoLKtGCp0j7rLg@public.gmane.org>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 06:39:21PM +0200, Andi Kleen wrote:
> 
> http://bugme.osdl.org/show_bug.cgi?id=3077
> 
> Some IRDA chipsets currently don't work on x86-64, because
> they're dependent on CONFIG_ISA and x86-64 doesn't set this.
> CONFIG_ISA means real ISA slots, and I doubt these chips
> come on real ISA cards, so I just removed the bogus 
> dependency.
> 
> Please apply.
> 
> -Andi

	I was because those driver were using isa_virt_to_bus. I think
we can drop that now, but I don't have the problematic
architecture. Well, I guess we will learn soon enough :-(
	Feel free to send that to Jeff. I currently have family, so
will take time to process my patch queue.
	Regards,

	Jean


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
