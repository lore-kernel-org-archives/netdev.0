From: "Ramkrishna Vepa" <ram.vepa@neterion.com>
Subject: RE: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Mon, 2 May 2005 19:58:38 -0700
Message-ID: <03d401c54f8c$03917fd0$5c10100a@pc.s2io.com>
References: <Pine.LNX.4.61.0505021844480.16692@linux.site>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        <muhammad.shafiq@neterion.com>, <ramkrishna.vepa@neterion.com>,
        <netdev@oss.sgi.com>,
        "'Ravinandan Arakali'" <ravinandan.arakali@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>, "'Anton Blanchard'" <anton@samba.org>
In-Reply-To: <Pine.LNX.4.61.0505021844480.16692@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I didnt know mmiowb is supposed to be a replacement for PCI write
> > posting. Most architectures define mmiowb as nothing and so will be
> > broken with your change.
> >
> 
> I thought that an arch was supposed to define mmiowb() if it needs
> it. In this case, the readq() is only being used for the side-effect
> of ordering the previous writes (the neterion folks can correct me
> if I'm wrong).
[Ram] Yes, it is to ensure ordering as well as the flush of the io that is
required in some platforms.
 
> 
> --
> Arthur
