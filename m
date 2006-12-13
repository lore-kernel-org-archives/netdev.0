From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Wed, 13 Dec 2006 12:05:20 -0500
Message-ID: <20061213170520.GE26412@csclub.uwaterloo.ca>
References: <200612031919.05228.IvDoorn@gmail.com> <a32f33a40612090505j23251626k891edae1c06b6fb2@mail.gmail.com> <20061213154415.GA26415@csclub.uwaterloo.ca> <200612131747.42035.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:33656 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965032AbWLMRFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:05:21 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200612131747.42035.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 05:47:41PM +0100, Ivo van Doorn wrote:
> Do you need to actually write data to the eeprom chip?
> Currently the module does not support writing to the eeprom,
> this is something I could add (The original Ralink code, where this module
> is based on also contains the code to write to the EEPROM).

I am going to use it to write the custom pci vendor ID to the eeprom, so
yes I intend to write to it.  The code appears as if it has the ability
to write to the eeprom but I didn't look at all of it carefully yet.  I
don't actually have any need to read it back, although I intend to do so
to verify the contents.

--
Len Sorensen
