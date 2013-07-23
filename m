From: JP Abgrall <jpa@google.com>
Subject: Re: Question about default route handling/lookup in a custom table
Date: Tue, 23 Jul 2013 10:58:57 -0700
Message-ID: <CAKP4w2S35T7FGuVDfvT1P+UNcDn0OOD2jmjt8Wo8uRtcgXeeCQ@mail.gmail.com>
References: <CAKP4w2Q_5V=2CdyUpeXrHg=dTv1LNynp87gy6nrQYWYyBuA39A@mail.gmail.com>
 <20130723134715.GC32523@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: JP Abgrall <jpa@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33570 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657Ab3GWR7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:59:18 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so10709832obc.17
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 10:59:17 -0700 (PDT)
In-Reply-To: <20130723134715.GC32523@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 6:47 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mon, Jul 22, 2013 at 06:20:18PM -0700, JP Abgrall wrote:
>>        ip route add 1.1.1.1/32 dev wlan0 table 60
>
> I am not sure but would have expected that you needed to add a rule e.g. ip
> rule add oif wlan0 table 60 to successfully match the next route insertion.

Works. Thanks. Shows how much more I need to learn. Will go dig into
the code to understand it better.
--
