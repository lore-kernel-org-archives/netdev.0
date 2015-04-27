From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Use PATH_MAX instead of MAXPATHLEN
Date: Mon, 27 Apr 2015 09:13:34 -0700
Message-ID: <20150427091334.01323146@urahara>
References: <20150425203327.GA9433@euler>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33175 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbbD0QNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 12:13:30 -0400
Received: by pdbnk13 with SMTP id nk13so133183741pdb.0
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 09:13:30 -0700 (PDT)
In-Reply-To: <20150425203327.GA9433@euler>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Apr 2015 22:33:28 +0200
Felix Janda <felix.janda@posteo.de> wrote:

> They are equivalent but the former is more common. PATH_MAX is
> specified by POSIX and needs <limits.h> while MAXPATHLEN has BSD
> origin and needs <sys/param.h>.
> 
> PATH_MAX has already been in use in misc/lnstat.h.
> 
> Signed-off-by: Felix Janda <felix.janda@posteo.de>

Iproute2 is intended for use on Linux.
It makes more sense to align with Posix than using leftover
BSD stuff. Therefore I don't see any point in doing this.
