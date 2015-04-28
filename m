From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH iproute2] Use PATH_MAX instead of MAXPATHLEN
Date: Tue, 28 Apr 2015 15:47:03 -0700
Message-ID: <55400DE7.9080501@gmail.com>
References: <20150425203327.GA9433@euler> <20150427091334.01323146@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34749 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031021AbbD1WrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:47:07 -0400
Received: by pacyx8 with SMTP id yx8so9004738pac.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 15:47:07 -0700 (PDT)
In-Reply-To: <20150427091334.01323146@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/15 09:13, Stephen Hemminger wrote:
> On Sat, 25 Apr 2015 22:33:28 +0200
> Felix Janda <felix.janda@posteo.de> wrote:
> 
>> They are equivalent but the former is more common. PATH_MAX is
>> specified by POSIX and needs <limits.h> while MAXPATHLEN has BSD
>> origin and needs <sys/param.h>.
>>
>> PATH_MAX has already been in use in misc/lnstat.h.
>>
>> Signed-off-by: Felix Janda <felix.janda@posteo.de>
> 
> Iproute2 is intended for use on Linux.
> It makes more sense to align with Posix than using leftover
> BSD stuff. Therefore I don't see any point in doing this.

My reading from Felix's commit message is that he is attempting to do
exactly that: conform to POSIX rather than BSD, which seems to be the
direction you are also suggesting here.
-- 
Florian
