From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Getting make net/built-in.o Error with 2.6.21.1
	Build
Date: Tue, 08 May 2007 19:50:10 +0200
Message-ID: <1178646610.8628.78.camel@aeonflux.holtmann.net>
References: <463FB6B0.3070005@pcburn.com>
	<a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
	<Pine.LNX.4.64.0705081740550.16923@twin.jikos.cz>
	<a781481a0705080905l609dc925s93357e6eb0d4c318@mail.gmail.com>
	<Pine.LNX.4.64.0705081815130.16923@twin.jikos.cz>
	<1178642912.8628.70.camel@aeonflux.holtmann.net>
	<Pine.LNX.4.64.0705081944450.16923@twin.jikos.cz>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam.sharma@gmail.com>, chris@pcburn.com,
	bluez-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jikos@jikos.cz>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0705081944450.16923@twin.jikos.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Jiri,

> > > Marcel - are you aware of any devices currently supported by USB HID 
> > > force-feedback code, which have a bluetooth version, please?
> > I haven't looked at all details for the PS3 controller, but that might
> > be the first one. In theory they can and at some point they will enter
> > the market.
> 
> You are right, PS3 controller is going to be shipped in both variants. On 
> the other hand it is perfectly possible that we will need special 
> force-feedback driver for it anyway.
> 
> BTW when talking about this - we already have PS3 quirk present in usb hid 
> (extra control URB is required to make it operational), probably something 
> similar will be needed for BT version too.

I know, but we do that in user space before we hand over the control to
the kernel. It is simpler, because it is on the control channel and that
part is not nicely integrated into the HID subsystem to be used by the
transport layers right now. At least as far as I can tell.

Regards

Marcel



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
