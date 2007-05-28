From: "=?ISO-8859-1?Q?Mart=EDn_Ferrari?=" <martin.ferrari@gmail.com>
Subject: Re: IFF_PROMISC again
Date: Mon, 28 May 2007 19:07:43 -0300
Message-ID: <b9800b70705281507r593ca9a3m18cbd3e6ac446587@mail.gmail.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
	 <465385F2.7080309@candelatech.com>
	 <b9800b70705252328x6318c85es922e81662ce41762@mail.gmail.com>
	 <20070527094923.3b4705b6@freepuppy>
	 <b9800b70705271805h4613ad14u33b754d12b80af34@mail.gmail.com>
	 <20070527235819.3695a2a1@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ben Greear" <greearb@candelatech.com>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:44759 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbXE1WHp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 18:07:45 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1015231nzf
        for <netdev@vger.kernel.org>; Mon, 28 May 2007 15:07:44 -0700 (PDT)
In-Reply-To: <20070527235819.3695a2a1@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

On 5/28/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> > Great that you point it out. Then, we're back to the initial
> > situation, there is no reliable way of polling promisc state, and I=
 am
> > looking for a way to do that. Ways I think it could be done:
>
> Back to the original question. Why should an application care?

Not an application, but the sysadmin do cares about it. And most
rootkit detectors don't have any other way of checking if a
tcpdump-like tool is running.

I don't see the usefulness of keeping the current toggle via gflags,
which is confusing for users. But I see a benefit in exporting
promiscuity as a read-only value, and I think it's pretty trivial to
provide it.

--=20
Mart=EDn Ferrari
