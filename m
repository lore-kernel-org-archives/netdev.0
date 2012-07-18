From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] b44: add 64 bit stats
Date: Wed, 18 Jul 2012 05:18:50 +0200
Message-ID: <1342581530.2626.1291.camel@edumazet-glaptop>
References: <1342337165.3265.10640.camel@edumazet-glaptop>
	 <CABF+-6VZB=V1j2cAzhNkJozvcVs=VrQGYX_71HiZJ+g6od7qyA@mail.gmail.com>
	 <CABF+-6W0B0wB7hAfSRh83aEb_XPqaJuzA1nKZJygdd9xw-rN1g@mail.gmail.com>
	 <20120716.230806.242760837075045729.davem@davemloft.net>
	 <CABF+-6WmaLjgTTX_ot=QCzsM-tYMJhVk5oRYFAVj66cKG-z31A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:53481 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab2GRDS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 23:18:59 -0400
Received: by vcbfk26 with SMTP id fk26so789568vcb.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 20:18:57 -0700 (PDT)
In-Reply-To: <CABF+-6WmaLjgTTX_ot=QCzsM-tYMJhVk5oRYFAVj66cKG-z31A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 22:02 -0400, Kevin Groeneveld wrote:
> On Tue, Jul 17, 2012 at 2:08 AM, David Miller <davem@davemloft.net> wrote:
> > This patch was corrupted by your email client and is therefore
> > unusable.
> 
> If I resend the patch should I bump the version number in the subject?
> 
It doesnt matter in this case, its a formatting issue

> Should I include "Acked-by" lines that people have posted?
> 

You can if no semantic change is done

> I keep sending myself test messages with the patch but the white space
> is always mangled.  I am not sure if Thunderbird is mangling it in the
> sent message or the received message... :(

Documentation/email-clients.txt

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Thunderbird (GUI)

Thunderbird is an Outlook clone that likes to mangle text, but there are ways
to coerce it into behaving.

- Allows use of an external editor:
  The easiest thing to do with Thunderbird and patches is to use an
  "external editor" extension and then just use your favorite $EDITOR
  for reading/merging patches into the body text.  To do this, download
  and install the extension, then add a button for it using
  View->Toolbars->Customize... and finally just click on it when in the
  Compose dialog.

To beat some sense out of the internal editor, do this:

- Edit your Thunderbird config settings so that it won't use format=flowed.
  Go to "edit->preferences->advanced->config editor" to bring up the
  thunderbird's registry editor, and set "mailnews.send_plaintext_flowed" to
  "false".

- Disable HTML Format: Set "mail.identity.id1.compose_html" to "false".

- Enable "preformat" mode: Set "editor.quotesPreformatted" to "true".

- Enable UTF8: Set "prefs.converted-to-utf8" to "true".

- Install the "toggle wordwrap" extension.  Download the file from:
    https://addons.mozilla.org/thunderbird/addon/2351/
  Then go to "tools->add ons", select "install" at the bottom of the screen,
  and browse to where you saved the .xul file.  This adds an "Enable
  Wordwrap" entry under the Options menu of the message composer.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
