From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] Check the value of doi before referencing it
Date: Wed, 18 May 2011 18:32:17 -0400
Message-ID: <201105181832.18196.paul.moore@hp.com>
References: <1305692980-4730-1-git-send-email-huzaifas@redhat.com> <20110518.010453.1295824792800350412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, kuznet@ms2.inr.ac.ru
To: huzaifas@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:11069 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010Ab1ERWcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:32:22 -0400
In-Reply-To: <20110518.010453.1295824792800350412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, May 18, 2011 1:04:53 AM David Miller wrote:
> From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
> Date: Wed, 18 May 2011 09:59:40 +0530
> 
> > Value of doi is not checked before referencing it.
> > Though this does not cause any null pointer dereference since
> > all the callers of cipso_v4_doi_add check the value of doi
> > before calling the function, but it would be a good programming
> > practice to do so anyways :)
> > 
> > Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>
> 
> I don't think we should fix bugs that do not exist.

I agree with David.

If there were a large number of callers or cipso_v4_doi_add() was a more 
general function there might be some merit in performing more sanity checks on 
the values passed to the function.  However, as it stands, cipso_v4_doi_add() 
is a fairly specialized function which is called by a small number of 
functions all of which are internal to NetLabel.

--
paul moore
linux @ hp
