From: Andrew Morton <akpm@osdl.org>
Subject: Re: pm_register should die
Date: Mon, 12 Sep 2005 02:41:45 -0700
Message-ID: <20050912024145.3c4298ec.akpm@osdl.org>
References: <20050912093456.GA29205@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@zip.com.au, torvalds@osdl.org,
	vojtech@suse.cz, dwmw2@infradead.org, netdev@vger.kernel.org,
	benjamin_kong@ali.com.tw, dagb@cs.uit.no, jgarzik@pobox.com,
	davidm@snapgear.com, twoller@crystal.cirrus.com, alan@redhat.com,
	mm@caldera.de, scott@spiteful.org, jsimmons@transvirtual.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751277AbVILJqM@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050912093456.GA29205@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> wrote:
>
> +#ifdef CONFIG_OLD_PM
>   	if (pm_send_all(PM_SUSPEND, (void *)3)) {

Can we not do this without ifdefs?

#define pm_send_all(foo, bar) 0

?
