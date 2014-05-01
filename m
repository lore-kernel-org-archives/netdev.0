From: Andy Lutomirski <luto@amacapital.net>
Subject: Connecting to sockets on MNT_READONLY mounts?
Date: Thu, 1 May 2014 15:20:00 -0700
Message-ID: <CALCETrUXbS4BMWMd0XXgFqyvmpu+WML840_mzbPiov8WmaA=Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is it supposed to work?  It does, but this seems odd.  If the current
behavior is intentional, then I'll submit a patch to add a new mount
flag to turn off ipc.  If it's not, then I'll submit a patch to fix
it.

-- 
Andy Lutomirski
AMA Capital Management, LLC
