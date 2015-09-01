From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 01 Sep 2015 09:58:56 +0200
Message-ID: <1441094336.3328.1.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
	 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	 <1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
	 <87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
	 <87mvxbzta9.fsf@nemi.mork.no> <55E03B28.6050305@rosalab.ru>
	 <87io7vzzdl.fsf@nemi.mork.no> <55E41557.1060803@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E41557.1060803@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-08-31 at 11:50 +0300, Eugene Shatokhin wrote:
> > But I would have liked it much better if the code became simpler
> instead
> > of more complex.
> 
> Me too, but I can see no other way here. The code is simpler without 
> locking, indeed, but locking is needed to prevent the problems
> described 
> earlier.

On a practical note, will you resend the patch?

	Regards
		Oliver
