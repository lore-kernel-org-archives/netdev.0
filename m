From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/3] Remove casts to same type
Date: Mon, 04 Jun 2012 21:54:29 -0700
Message-ID: <1338872069.20167.7.camel@joe2Laptop>
References: <cover.1338849364.git.joe@perches.com>
	 <CAJfuBxzVLzQK_d=JqJVzQnzHWZDtAJMihkEXWh7xeimMq9FHxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jim Cromie <jim.cromie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42980 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750757Ab2FEEya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 00:54:30 -0400
In-Reply-To: <CAJfuBxzVLzQK_d=JqJVzQnzHWZDtAJMihkEXWh7xeimMq9FHxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 22:48 -0600, Jim Cromie wrote:
> On Mon, Jun 4, 2012 at 4:44 PM, Joe Perches <joe@perches.com> wrote:
> > Adding casts of objects to the same type is unnecessary
> > and confusing for a human reader.
> > Remove them via coccinelle script.
> Can you also post the coccinelle script ?

Hi Jim.

I did that with each patch, but here it is again:

$ cat norecast.cocci
@@
type T;
T *p;
@@

-       (T *)p
+       p
$

> did you have to edit them any futher, or is it 100% script ?

Also from each patch:

I manually removed the conversions this script produces of
casts with __force, __iomem and __user.

Also, I did delete a few unnecessary parentheses left over
after the casts were removed.
