From: jamal <hadi@cyberus.ca>
Subject: Re: duplicated u32 filters in tc show output
Date: Sun, 07 Oct 2007 12:43:19 -0400
Message-ID: <1191775399.4394.45.camel@localhost>
References: <20071006131056.GA17693@toroid.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Abhijit Menon-Sen <ams@toroid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:1996 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbXJGQnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 12:43:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1044688wxd
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2007 09:43:22 -0700 (PDT)
In-Reply-To: <20071006131056.GA17693@toroid.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-06-10 at 18:40 +0530, Abhijit Menon-Sen wrote:
> The HTB user guide (http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm)
> says the following:
> 
>     Note: The U32 classifier has an undocumented design bug which causes
>     duplicate entries to be listed by "tc filter show" when you use U32
>     classifiers with different prio values.
> 
> What exactly is this bug? (I'm seeing its effects, i.e. the duplicates,
> and it's making my life a little difficult while trying to parse the tc
> output.)

If it is the bug i think it is - then it was fixed a long time ago; the
doc you are referencing seemed to be dated. 
Try a newer kernel if you are not and if it still persists, send the
simplest setup you have that causes duplicates.

cheers,
jamal


