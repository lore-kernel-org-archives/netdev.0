From: "Ramkrishna Vepa" <ram.vepa@neterion.com>
Subject: RE: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
Date: Tue, 3 May 2005 09:23:07 -0700
Message-ID: <03d701c54ffc$651958c0$5c10100a@pc.s2io.com>
References: <Pine.LNX.4.61.0505030750010.16692@linux.site>
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
In-Reply-To: <Pine.LNX.4.61.0505030750010.16692@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ordering is all that is required. We can get rid of the flush.

Ram

> -----Original Message-----
> From: Arthur Kepner [mailto:akepner@sgi.com]
> Sent: Tuesday, May 03, 2005 7:52 AM
> To: Anton Blanchard
> Cc: Ramkrishna Vepa; 'Leonid Grossman'; muhammad.shafiq@neterion.com;
> ramkrishna.vepa@neterion.com; netdev@oss.sgi.com; 'Ravinandan Arakali'
> Subject: Re: [PATCH] s2io: replace readq() with mmiowb() in s2io_xmit()
> 
> On Tue, 3 May 2005, Anton Blanchard wrote:
> 
> >
> > > [Ram] Yes, it is to ensure ordering as well as the flush of the io
> that is
> > > required in some platforms.
> >
> > If the flush of the IO is required I cant see how we can remove the
> read.
> >
> 
> Agreed. Can someone from neterion comment? Is a flush required, or is
> ordering all that's required here?
> 
> --
> Arthur
