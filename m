From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] ipv4: coding style: comparison for
 equality with NULL
Date: Fri, 03 Apr 2015 09:51:15 -0700
Message-ID: <1428079875.13180.14.camel@perches.com>
References: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
	 <1428049047-14783-2-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0086.hostedemail.com ([216.40.44.86]:48323 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752082AbbDCQvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:51:18 -0400
In-Reply-To: <1428049047-14783-2-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 09:17 +0100, Ian Morris wrote:
> The ipv4 code uses a mixture of coding styles. In some instances check
> for NULL pointer is done as x == NULL and sometimes as !x. !x is
> preferred according to checkpatch and this patch makes the code
> consistent by adopting the latter form.

Thanks Ian.

>  39 files changed, 210 insertions(+), 202 deletions(-)

A change like this would generally not add or remove lines.

It'd be nice if in the future, when a substitution like
this occurs and lines counts are changed that the commit
log states why.

For this case, maybe something like:

Hoisted a few assignments from if statements while there.
