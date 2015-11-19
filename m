From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 12:41:34 +0100
Message-ID: <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos>
 <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos>
 <564CDE2F.8000201@profihost.ag> <564CEB0C.40006@redhat.com>
 <564CEF5D.3080005@profihost.ag> <564D9A17.6080305@redhat.com>
 <564D9B21.302@profihost.ag> <564D9CE6.2090104@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Stefan Priebe - Profihost AG" <s.priebe@profihost.ag>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564D9CE6.2090104@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015, at 10:56, Stefan Priebe - Profihost AG wrote:
> OK it had a livelock again. It just took more time.
> 
> So here is the data:

Thanks, I couldn't reproduce it so far with simple threaded resolver
loop on your kernel. :/

Your data is useless if you don't also provide the file descriptor which
you are blocking on right now. ;)

Thanks,
Hannes
