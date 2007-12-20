From: Justin Banks <justinb@bakbone.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Thu, 20 Dec 2007 13:49:59 -0700
Message-ID: <20071220204958.GA7898@bleen.domain.actdsltmp>
References: <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr> <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com> <4768123A.7040603@cosmosbay.com> <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com> <47682F8C.20205@cosmosbay.com> <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com> <47694FCC.1020507@cosmosbay.com> <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com> <47695CEF.4090908@cosmosbay.com> <83a51e120712200808m7fa63e9jc588124a6da5f740@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Jan Engelhardt <jengelh@computergmbh.de>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761000AbXLTU5Z@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <83a51e120712200808m7fa63e9jc588124a6da5f740@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Nichols wrote
> > I still dont understand.
> >
> > "tcpdump -p -n -s 1600 -c 10000" doesnt reveal User data at all.
> >
> > Without any exact data from you, I am afraid nobody can help.
> 
> Oh, I didn't see that you specified specific options.  I'll still have
> to anonymize 2000+ IP addresses, but I think there is an open source
> tool that will do this for you.


tcpdump -p -n -s 1600 -c 10000 | perl -pe 's/(\d+\.\d+\.\d+\.\d+)/HIDE.THIS.IP.ADDR/g'

-justinb

-- 
Justin Banks
BakBone Software
justinb@bakbone.com
