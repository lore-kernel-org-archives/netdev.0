From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH net-next 1/3] ptp: Allow reassigning calibration pin function
Date: Thu, 26 Jun 2014 08:16:13 +0200
Message-ID: <CABkLOboU72WkULxGBZUAKFHOgPBaEDB0-coQ+tjOFSLb9Qaj4Q@mail.gmail.com>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
	<1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
	<20140626052144.GB4537@netboy>
	<CABkLOboZDJr8tr5JpaUijuNcJ7j7L8nMU33TC0WMn4iir-qVAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Stefan_S=C3=B8rensen?= <stefan.sorensen@spectralink.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:46677 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbaFZGQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 02:16:14 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so2433825qac.32
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 23:16:13 -0700 (PDT)
In-Reply-To: <CABkLOboZDJr8tr5JpaUijuNcJ7j7L8nMU33TC0WMn4iir-qVAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 8:14 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Yes, indeed, but isn't that a bug? I think the calibration should be
> done again whenever the clock is loaded with a new value, i.e. in
> ptp_dp83640_settime. See section 3.1 in [1]: "All subsequent settings
> should use a step
> adjustment or temporary rate adjustment, which should occur at each
> PHY without introducing any error." This means, whenever we do
> something else (directly write to the clock register), we must
> recalibrate.

Forgot to paste the link:
[1] http://www.ti.com/lit/pdf/snla104

Sorry.
