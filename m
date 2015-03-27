From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4 route
Date: Fri, 27 Mar 2015 10:37:46 -0400
Message-ID: <CACP96tTEcrAm_y7j9EtZLxViy1EtvyCJAbUw+fnhG-WMbRikAg@mail.gmail.com>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
	<1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
	<CACP96tQjVxSgh3m7ext5P+iyY2tPXy3O6R+UQ4wv44MRjFQvZQ@mail.gmail.com>
	<20150327143522.GH1051@gospo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Bjornar Ness <bjornar.ness@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37969 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbbC0Ohr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 10:37:47 -0400
Received: by wibgn9 with SMTP id gn9so34010611wib.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 07:37:46 -0700 (PDT)
In-Reply-To: <20150327143522.GH1051@gospo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:35 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:

>
> You are correct that there is not a great way to construct this since
> the frames at strictly IPv4 frames.  I'll have to dig into this a bit
> more to see if there is something worth doing for this case.

Most of the complexity is probably the router-side behavior (for when/how
to construct redirects). I suspect the host side should be straight-forward,
and not too much change.

--Sowmini
