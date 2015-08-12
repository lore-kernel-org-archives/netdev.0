From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/4] batman-adv: fix kernel crash due to missing NULL
 checks
Date: Wed, 12 Aug 2015 08:44:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB7939D@AcuExch.aculab.com>
References: <1438779107-12665-1-git-send-email-antonio@meshcoding.com>
 <1438779107-12665-3-git-send-email-antonio@meshcoding.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB737B7@AcuExch.aculab.com>
 <55CA2605.1070201@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
	"Marek Lindner" <mareklindner@neomailbox.ch>
To: 'Antonio Quartulli' <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:65027 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbbHLIrU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:47:20 -0400
In-Reply-To: <55CA2605.1070201@meshcoding.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli
> Sent: 11 August 2015 17:43
> On 05/08/15 15:15, David Laight wrote:
> > So is this test just hiding anoter bug somewhere??
> 
> Hi David and thanks for your feedback.
> 
> The point is that we got several bug reports of kernel crashes due to
> NULL pointer deferences in these lines and after having debugged this
> problem for quite a while we preferred to move on and propose this patch.

That is what I thought.

> Still, I am personally debugging this part of the code to understand if
> we really have something wrong or if this NULL pointer is something we
> should expect (and therefore check).
> 
> For the time being we think this patch is better than having horrible
> kernel crashes, but I hope to come to a definitive conclusion soon.

If you don't know why you are seeing the NULL pointer then you are
just papering over some cracks and it is likely that something
is really badly wrong somewhere (ie missing locking).
This could easily mean that there are some much harder to find
bugs lurking there.

	David
