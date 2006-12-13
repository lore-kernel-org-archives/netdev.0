From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Wed, 13 Dec 2006 18:17:23 +0100
Message-ID: <200612131817.23735.IvDoorn@gmail.com>
References: <200612031919.05228.IvDoorn@gmail.com> <200612131747.42035.IvDoorn@gmail.com> <20061213170520.GE26412@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:36474 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965046AbWLMRRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:17:35 -0500
Received: by nf-out-0910.google.com with SMTP id o25so575973nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 09:17:33 -0800 (PST)
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20061213170520.GE26412@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 December 2006 18:05, Lennart Sorensen wrote:
> On Wed, Dec 13, 2006 at 05:47:41PM +0100, Ivo van Doorn wrote:
> > Do you need to actually write data to the eeprom chip?
> > Currently the module does not support writing to the eeprom,
> > this is something I could add (The original Ralink code, where this module
> > is based on also contains the code to write to the EEPROM).
> 
> I am going to use it to write the custom pci vendor ID to the eeprom, so
> yes I intend to write to it.  The code appears as if it has the ability
> to write to the eeprom but I didn't look at all of it carefully yet.  I
> don't actually have any need to read it back, although I intend to do so
> to verify the contents.

Currently the module does not contain any code to actually write to
the eeprom. I'll create a patch to add support for the writing.
