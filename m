From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Tue, 22 Apr 2008 19:17:39 -0700
Message-ID: <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
References: <480E8523.4030007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Network Development list" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:54575 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYDWCRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 22:17:40 -0400
Received: by wa-out-1112.google.com with SMTP id m16so4283230waf.23
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 19:17:39 -0700 (PDT)
In-Reply-To: <480E8523.4030007@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2008 at 5:38 PM, Rick Jones <rick.jones2@hp.com> wrote:
>  oslowest:~# netstat -an | grep ESTAB
>  ...
>  tcp    0 2760560 10.208.0.1:40500    10.208.0.45:42049   ESTABLISHED
>  ...
>
>  Is this expected behaviour?

What is your interface txqueuelen and mtu?  If you have a very large
interface queue, TCP will happily fill it up unless you are using a
delay-based congestion controller.

  -John
