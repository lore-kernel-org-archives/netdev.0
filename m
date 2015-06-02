From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net V1] ethtool: Support for configurable RSS hash function
Date: Tue, 2 Jun 2015 09:31:32 +0300
Message-ID: <CAPcc5PgiKoT4=9u3J7Dcmt_Fy7Wc+wPk5p3=qeK2tQRpCzVQbg@mail.gmail.com>
References: <1430133773-11613-1-git-send-email-amirv@mellanox.com>
	<CAPcc5PigfcBCZV=z+Q15+0xBXh_GEyGEz6RASPCXtQvTXadP0w@mail.gmail.com>
	<1433102761.6319.111.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0053.outbound.protection.outlook.com ([157.55.234.53]:5024
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752854AbbFBGbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 02:31:39 -0400
Received: by wifw1 with SMTP id w1so131646791wif.0
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 23:31:32 -0700 (PDT)
In-Reply-To: <1433102761.6319.111.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 31, 2015 at 11:09 PM Ben Hutchings <ben@decadent.org.uk> wrote:
>
> On Tue, 2015-05-05 at 18:48 +0300, Amir Vadai wrote:
> > On Mon, Apr 27, 2015 at 2:22 PM, Amir Vadai <amirv@mellanox.com> wrote:
> > > From: Eyal Perry <eyalpe@mellanox.com>
> > >
> > > This ethtool patch adds support to set and get the current RSS hash
> > > function for the device through through the new hfunc field in the
> > > ethtool_rxfh struct. Kernel supported hash function names are queried
> > > with ETHTOOL_GSTRINGS (value 0 is reserved and skipped).
> > >
> > > Although currently no device supports a combination of hash
> > > functions/attributes, this ethtool implementation will support it. Both in the
> > > set and in the get.
> > > The device driver declares the functions and/or attributes that it supports,
> > > and ethtool will show it correctly and enable the user to set those
> > > combinations.
> > > If a combination is not supported - the device driver will fail the operation
> > > and ethtool will print an error message.
> > >
> > > Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> > > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > > ---
> > > Changes from V1:
> > > - Fixed some English mistakes
> > > - Fixed the complicated way to write '= req_hfunc;'...
> > > - Better support in combination of hash functions/attributes
> >
> > Ben Hi,
> >
> > Could you take a look at this patch?
>
> Didn't we agree that only one hash function should be selected at once?
> Can you send a new version that implements that?
Yeh, and actually I did send a V1 according to that approach, but Dave
Miller has suggested [1] that we might add control attributes in
combination to the hash function.

[1] - http://permalink.gmane.org/gmane.linux.network/360812

Amir

>
> Ben.
>
> --
> Ben Hutchings
> Reality is just a crutch for people who can't handle science fiction.
