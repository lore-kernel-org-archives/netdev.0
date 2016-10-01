From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] realtek: rtl8xxxu: Use const init arrays
Date: Sat, 01 Oct 2016 14:08:42 -0700
Message-ID: <1475356122.1996.6.camel@perches.com>
References: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
         <wrfj37kf6gvd.fsf@redhat.com> <1475352058.1996.1.camel@perches.com>
         <wrfjponj4xpq.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0241.hostedemail.com ([216.40.44.241]:52401 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750946AbcJAVIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 17:08:45 -0400
In-Reply-To: <wrfjponj4xpq.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-10-01 at 16:32 -0400, Jes Sorensen wrote:
> Your output shows it moving to the text segment - if it's in a different
> segment, eg. rodata, you should use output demonstrating that to justify
> the change.

For size, rodata _is_ text
