From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 1/8] Only parse time stamp TCP option in time wait
 sock
Date: Wed, 21 Oct 2009 05:49:09 -0400
Message-ID: <4ADED915.7000107@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-2-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:56273 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbZJUJtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 05:49:08 -0400
Received: by ywh40 with SMTP id 40so4324255ywh.33
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 02:49:13 -0700 (PDT)
In-Reply-To: <1256115421-12714-2-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> A time wait socket is established - we already know if time stamp
> option is called for or not.
> 
Not so sure about this.  A timewait sock isn't actually established,
and new/changed options could appear.  There's all sorts of edge cases.

There's also some current work to note:

  http://tools.ietf.org/html/draft-ietf-tcpm-1323bis

  http://tools.ietf.org/html/draft-gont-tcpm-tcp-timestamps
