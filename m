From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH][RFC] ipconfig: Add new kernel parameter to force MAC
 address
Date: Fri, 21 Oct 2011 13:04:18 +0200
Message-ID: <20111021110418.GG651279@jupiter.n2.diac24.net>
References: <878vofr2t9.fsf@elisp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Naohiro Aota <naota@elisp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878vofr2t9.fsf@elisp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2011 at 02:27:30AM +0900, Naohiro Aota wrote:
> However it's not possible when you are using NFS root since the
> kernel already set the random MAC address and you cannot change
> it after system boot up process.

Is there any particular reason you're not using an initramfs?
Kernel autoconfiguration & NFS-root are relicts of old times, with an
initramfs you can start a proper portmap/rpcbind daemon and use full
regular NFS (v4 even).

... and you can change the MAC before bringing the interface up.


-David
