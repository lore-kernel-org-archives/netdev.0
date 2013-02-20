From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] ipv6: Split from and expires field in dst_entry out of union [net-next]
Date: Wed, 20 Feb 2013 12:08:34 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7158@saturn3.aculab.com>
References: <1361231718.19353.117.camel@edumazet-glaptop> <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7157@saturn3.aculab.com> <20130220120225.GA14501@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Gao feng" <gaofeng@cn.fujitsu.com>, "Jiri Bohac" <jbohac@suse.cz>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36758 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934395Ab3BTMJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 07:09:22 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11504-02 for <netdev@vger.kernel.org>;
 Wed, 20 Feb 2013 12:09:19 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20130220120225.GA14501@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Aren't there also problems with setting and clearing RTF_EXPIRES?
> > Since that flag looks as though it was the descriminant for the union
> > it probably isn't needed - provided dst.expires is never 0 when valid.
> >
> > 	David
>
> The use of RTF_EXPIRES is weak at this point, if there are multiple accessors,
> but I think the point is moot, in that the only thing we ever do when we change
> the flag is release dst.from, which is safe.
>
> Neil

I was also worried about the RMW cycles of rt6i_flags itself.

	David
