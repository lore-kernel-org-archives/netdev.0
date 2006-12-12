From: jamal <hadi@cyberus.ca>
Subject: Re: [IPROUTE2 PATCH][GENETLINK]  Add controller support for new
	features exposed
Date: Mon, 11 Dec 2006 20:31:04 -0500
Message-ID: <1165887064.4441.4.camel@localhost>
References: <1165426552.3749.15.camel@localhost>
	 <200612111737.59791.netdev@axxeo.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:30679 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbWLLBbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:31:09 -0500
Received: by wx-out-0506.google.com with SMTP id h27so1742317wxd
        for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 17:31:08 -0800 (PST)
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200612111737.59791.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-12 at 17:37 +0100, Ingo Oeser wrote:
> Hi Jamal,
> 
> jamal wrote:
> > +
> > +       if (fl & GENL_ADMIN_PERM)
> > +               fprintf(fp, " requires admin permission;");
> > +       if (fl & GENL_CMD_CAP_DO)
> > +               fprintf(fp, " can doit;");
> > +       if (fl & GENL_CMD_CAP_DUMP)
> > +               fprintf(fp, " can dumpit;");
> > +       if (fl & GENL_CMD_CAP_HASPOL)
> > +               fprintf(fp, " has policy");
> 
> Can't you think of sth. more admin/user friendly instead of "doit" and "dumpit"?
> iproute is cryptic enough already :-)
> 

I have to think a little about the best way to make this more friendly. 
If you have any suggestion please shoot. Lets have Stephen merge all the
patches then we can revisit. If you have time take a look at the genl
howto that Paul Moore has been tossing around and see if you can pick
some better language.

cheers,
jamal



