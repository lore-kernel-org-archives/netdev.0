From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Wed, 6 Dec 2006 17:10:56 -0500
Message-ID: <d120d5000612061410l3f4e0c4x60c5456c17ef4d61@mail.gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com>
	 <200612050027.15253.IvDoorn@gmail.com>
	 <d120d5000612060637s69ff235fo85a2db923a728a00@mail.gmail.com>
	 <200612062031.57148.IvDoorn@gmail.com>
	 <d120d5000612061218x4eac87e0jc18409f82bb7c99c@mail.gmail.com>
	 <20061206230546.41519771@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ivo van Doorn" <ivdoorn@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>,
	"Lennart Poettering" <lennart@poettering.net>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.224]:4334 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937719AbWLFWK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 17:10:58 -0500
Received: by hu-out-0506.google.com with SMTP id 34so5262279hui
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 14:10:56 -0800 (PST)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20061206230546.41519771@logostar.upir.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/6/06, Jiri Benc <jbenc@suse.cz> wrote:
> On Wed, 6 Dec 2006 15:18:12 -0500, Dmitry Torokhov wrote:
> > On 12/6/06, Ivo van Doorn <ivdoorn@gmail.com> wrote:
> > > Ok, so input device opening should not block the rfkill signal and the rfkill handler
> > > should still go through with its work unless a different config option indicates that
> > > userspace wants to handle the event.
> >
> > I don't think a config option is a good idea unless by config option
> > you mean a sysfs attribute.
>
> What about using EVIOCGRAB ioctl for this?
>

Will not work when the button is on your USB keyboard ;)

-- 
Dmitry
