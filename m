From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Wed, 14 Nov 2012 08:42:44 -0800 (PST)
Message-ID: <1636188668.22560872.1352911364387.JavaMail.root@vmware.com>
References: <50A01FB1.1080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net,
	George Zhang <georgezhang@vmware.com>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50A01FB1.1080502@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

Thanks for taking a look.

> So all the documentation I see in the VMCI Socket Programming Guide
> is about userspace programming, and the documentation in af_vsock.c
> is all around implementation considerations.

Agreed, we're sorely lacking in proper documentation for the internal
protocol.  We're in the process of writing such a specification and
will post it to LKML next week at the latest.

> example, whats the deal with REQUEST/REQUEST2? it appears like
> something to deal with legacy code, but I'd really like to have it
> documented somewhere instead of trying to figure how everything

Correct, we have a legacy protocol and a v2, the latter now being
the default.  This particular packet is sent by the client when
initiating a STREAM connection.  The sequence is REQUEST(2)->
NEGOTIATE(2)->OFFER->ACCEPT.  It will be properly documented in
the specification we post next week.

Thanks!
- Andy
