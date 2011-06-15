From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [Security] inet_diag insufficient validation?
Date: Wed, 15 Jun 2011 10:35:24 -0400
Message-ID: <1308148524.3718.0.camel@dan>
References: <1306942849.3150.10.camel@dan>
	 <BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	security@kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eugene Teo <eugeneteo@kernel.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:55154 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618Ab1FOOfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 10:35:39 -0400
In-Reply-To: <BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-03 at 14:55 +0800, Eugene Teo wrote:
> Cc'ed acme.
> 
> On Wed, Jun 1, 2011 at 11:40 PM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > It seems to me that the auditing performed by inet_diag_bc_audit() is
> > insufficient to prevent pathological INET_DIAG bytecode from doing bad
> > things.
> >
> > Firstly, it's possible to cause an infinite loop in inet_diag_bc_audit()
> > with a INET_DIAG_BC_JMP opcode with a "yes" value of 0.  The valid_cc()
> > function, also called from here, seems suspicious as well.
> >

Any chance of getting this fixed?  I have a reproducer available if
necessary.

-Dan

