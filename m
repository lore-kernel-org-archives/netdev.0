From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v2] tc: Show classes in tree view
Date: Tue, 23 Dec 2014 09:10:41 +0200
Message-ID: <20141223071041.GA25809@angus-think.lan>
References: <1419263518-14434-1-git-send-email-vadim4j@gmail.com>
 <20141222173554.349bb18c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:54700 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbaLWHUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 02:20:49 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so5142957lab.11
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 23:20:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141222173554.349bb18c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 05:35:54PM -0800, Stephen Hemminger wrote:
> On Mon, 22 Dec 2014 17:51:58 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > +	while (cls && cls->cls_parent) {
> > +		cls->cls_parent->cls_right = cls;
> > +		cls = cls->cls_parent;
> > +	}
> > +	while (cls && cls->cls_right)
> > +	{
> 
> Why the sudden shift of bracketing style?
Oh no, it happened, in company where I work they uses different style, sorry ...

Thanks,
