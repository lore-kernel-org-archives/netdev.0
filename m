From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: possible patch
Date: Wed, 10 Feb 2016 18:25:35 -0700
Message-ID: <20160210182535.5d46bbca@lwn.net>
References: <CALah4Nc5Bx6FYfSnQWNaSd3YpurhKU1viqZx1KdU_M6sO0cG2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: Justin Keller <justincompsci@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALah4Nc5Bx6FYfSnQWNaSd3YpurhKU1viqZx1KdU_M6sO0cG2Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Feb 2016 19:49:11 -0500
Justin Keller <justincompsci@gmail.com> wrote:

> I am new to submitting patches, so sorry if I am doing it wrong. My idea was
> to change line 147 in drivers/isdn/pcbit/callbacks.c from
> if (cbdata->data.setup.CallingPN == NULL) {
> 
> to
> 
> if (cbdata->data.setup.CallingPN == NULL ||
> sizeof(cbdata->data.setup.CallingPN)>sizeof(ictl.parm.setup.phone) {

If you want to patch the kernel, the best way to describe what you want to
do is to ... send a patch.

Before you do so, though:

- Please read the available documentation, including SubmittingPatches and
  development-process/*

- Prepare a proper changelog saying *why* you want to make this change.
  You are trying to change the ISDN subsystem, which is pretty static
  these days; what current problem are you running into that makes you
  think this change needs to be applied to the kernel?

Thanks,

jon
