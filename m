From: "Ramachandra K" <ariston@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Thu, 12 Jun 2008 21:20:27 +0530
Message-ID: <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	amar.mudrankit@qlogic.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:44604 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbYFLPub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 11:50:31 -0400
Received: by yx-out-2324.google.com with SMTP id 31so420588yxl.1
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 08:50:28 -0700 (PDT)
In-Reply-To: <484F751F.7030407@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2008 at 12:17 PM, Patrick McHardy <kaber@trash.net> wrote:
> Since I didn't receive anything but a "its too complex" in
> response to my previous question, let me ask again: why are
> you inventing a new sysfs interface (combined with ~15 module
> parameters) instead of using the existing standard interfaces
> for this?

Can you please elaborate on the standard interfaces you are referring to ?

Also as Roland mentioned in the other thread, echo-ing the parameters
to sysfs files
is a pretty straightforward way to configure the interfaces. Users
can setup configuration files to configure QLogic VNIC interfaces
specifying the name of the interface, various parameters of the
QLogic EVIC gateway target they want to use  and a simple user level
script parses the configuration file and echoes the parameters to the driver.

<snip>

>> +# An interface can be deleted by echoing the name of the interface to be
>> deleted
>> +# to delete_vnic file
>> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/delete_vnic
>
>
> This clearly shows the advantage of being able to use echo
> for configuration.

>From this statement, I thought you agreed with the advantage of echo for
configuration.

Regards,
Ram
