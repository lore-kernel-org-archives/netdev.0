From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 iproute2] bridge link: add option 'self'
Date: Wed, 24 Dec 2014 12:30:25 -0800
Message-ID: <20141224123025.2af99b41@urahara>
References: <1417854061-4675-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bCDTmR_zaVredZNzviaXc1YzXtSAK3dYj+BekiW9OKSpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJr?= =?UTF-8?B?bw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:42840 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbaLXUai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:30:38 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so10478894pdb.10
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:30:38 -0800 (PST)
In-Reply-To: <CAE4R7bCDTmR_zaVredZNzviaXc1YzXtSAK3dYj+BekiW9OKSpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 6 Dec 2014 09:12:51 -0800
Scott Feldman <sfeldma@gmail.com> wrote:

> Signed-of-by: Scott Feldman <sfeldma@gmail.com>
> 
> On Sat, Dec 6, 2014 at 12:21 AM,  <roopa@cumulusnetworks.com> wrote:
> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >
> > Currently self is set internally only if hwmode is set.
> > This makes it necessary for the hw to have a mode.
> > There is no hwmode really required to go to hardware. So, introduce
> > self for anybody who wants to target hardware.
> >
> > v1 -> v2
> >     - fix a few bugs. Initialize flags to zero: this was required to
> >     keep the current behaviour unchanged.
> >
> > v2 -> v3
> >     - fix comment
> >
> > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied to post 3.18 current tree.
