From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 5/6] net/core: support compiling out splice
Date: Sat, 22 Nov 2014 15:07:32 -0800
Message-ID: <20141122230731.GC24429@thin>
References: <1416690001-20817-1-git-send-email-pieter@boesman.nl>
 <1416690001-20817-6-git-send-email-pieter@boesman.nl>
 <20141122214853.GB23711@thin>
 <CAPho-_+GV+2sVVxGsPSjvE3heEoGa4chbqrmnxLAr_p7RU=TDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	Miklos Szeredi <mszeredi@suse.cz>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jan Beulich <JBeulich@suse.com>,
	open list <linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
To: Pieter Smith <pieter@boesman.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPho-_+GV+2sVVxGsPSjvE3heEoGa4chbqrmnxLAr_p7RU=TDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Please don't top-post.]

On Sat, Nov 22, 2014 at 11:50:51PM +0100, Pieter Smith wrote:
> splice exports a structure that is used by skbuf. Mocking out a function is
> straightforward. To my knowledge there is no elegant way of mocking out a
> splice_operations struct. I directly modified the code to prevent linking
> against the struct. Do you know of a better technique to get the same
> result?

No, I don't.  The approach you took seems fine; I'm just saying that you
need to explain the need for it in the commit message.

- JosH Triplett
