From: Heinz Diehl <htd@fancy-poultry.org>
Subject: Re: [REGRESSION]linux-2.6.35-rc3 in net/core/dev.c
Date: Sun, 13 Jun 2010 17:28:45 +0200
Message-ID: <20100613152845.GA6683@fancy-poultry.org>
References: <201006131625.55481.mitov@issp.bas.bg>
 <20100613165421.7e8dda79@holly>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100613165421.7e8dda79@holly>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.06.2010, Jindrich Makovicka wrote: 

> I can confirm this. Reverting of this patch fixes a regression with
> Privoxy running on localhost, where most of the connections
> (browser->proxy) stall and don't return anything.

This does also fix this bug:
https://bugzilla.kernel.org/show_bug.cgi?id=16188
