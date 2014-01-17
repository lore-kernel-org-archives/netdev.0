From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/3] net: add trim helper and convert users
Date: Fri, 17 Jan 2014 09:52:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EAC0@AcuExch.aculab.com>
References: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
 <1389918519-23779-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39386 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752066AbaAQJzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 04:55:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02154-06 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 09:55:11 +0000 (GMT)
In-Reply-To: <1389918519-23779-3-git-send-email-hannes@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa
...
> +/**
> + * trim - perform a reciprocal multiplication in order to "clamp" a
> + *        value into range [0, ep_ro), where the upper interval
> + *        endpoint is right-open. This is useful, e.g. for accessing
> + *        a index of an array containing ep_ro elements, for example.
> + *        Think of it as sort of modulus, only that the result isn't
> + *        that of modulo. ;)
> + *        More: http://homepage.cs.uiowa.edu/~jones/bcd/divide.html

It isn't appropriate to put urls into code comments (or commit messages).
They are very likely to get out of date.

	David
